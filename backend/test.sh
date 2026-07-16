#!/usr/bin/env bash
# 集成测试：针对运行中的服务 + 真实数据库，逐项断言真实结果
set -uf   # -f 关闭通配符扩展，避免 --noproxy 参数被 glob
BASE="http://127.0.0.1:8080"
req(){ curl -s --noproxy 127.0.0.1 "$@"; }
CURL=req
PASS=0; FAIL=0
ok(){ echo "  ✓ $1"; PASS=$((PASS+1)); }
no(){ echo "  ✗ $1"; FAIL=$((FAIL+1)); }
assert_eq(){ [ "$2" = "$3" ] && ok "$1 ($2)" || no "$1 期望=$3 实际=$2"; }
assert_ge(){ [ "$2" -ge "$3" ] 2>/dev/null && ok "$1 ($2>=$3)" || no "$1 期望>=$3 实际=$2"; }
jval(){ python3 -c "import sys,json;d=json.load(sys.stdin);print(eval(\"d$1\"))" 2>/dev/null; }

echo "== 1. 认证 =="
TOKEN=$($CURL -H "Content-Type: application/json" -d '{"number":"admin","password":"admin123"}' $BASE/api/auth/login | jval "['data']['token']")
[ -n "$TOKEN" ] && ok "admin 登录成功，获得 token" || no "登录失败"
BAD=$($CURL -H "Content-Type: application/json" -d '{"number":"admin","password":"x"}' $BASE/api/auth/login | jval "['code']")
assert_eq "错误密码被拒" "$BAD" "500"
UNAUTH=$($CURL -o /dev/null -w "%{http_code}" $BASE/api/goods)
assert_eq "无 token 访问返回 401" "$UNAUTH" "401"
AUTH="-H token:$TOKEN"

echo "== 2. 统计（真实聚合）=="
TOTAL=$($CURL $AUTH $BASE/api/stats/kpi | jval "['data']['totalStock']")
GSUM=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT SUM(count) FROM goods" 2>/dev/null)
assert_eq "总库存 == SUM(goods.count)" "$TOTAL" "$GSUM"
CATN=$($CURL $AUTH $BASE/api/stats/category | jval "|len(d['data'])|" 2>/dev/null)
CATN=$($CURL $AUTH $BASE/api/stats/category | python3 -c "import sys,json;print(len(json.load(sys.stdin)['data']))")
assert_ge "分类占比返回多类" "$CATN" "5"

echo "== 3. 热力图（真实库存驱动）=="
STN=$($CURL $AUTH $BASE/api/heatmap/storages | python3 -c "import sys,json;print(len(json.load(sys.stdin)['data']))")
assert_ge "有库位的仓库数" "$STN" "8"
BINS=$($CURL $AUTH "$BASE/api/heatmap?storageId=2" | python3 -c "import sys,json;print(len(json.load(sys.stdin)['data']['bins']))")
assert_eq "数码仓库库位数=32" "$BINS" "32"
OCCSUM=$($CURL $AUTH "$BASE/api/heatmap?storageId=2" | python3 -c "import sys,json;d=json.load(sys.stdin)['data']['bins'];print(sum(b['stock'] for b in d))")
DBSUM=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT COALESCE(SUM(ls.count),0) FROM location_stock ls JOIN location l ON l.id=ls.location_id WHERE l.storage_id=2" 2>/dev/null)
assert_eq "库位存货合计 == location_stock" "$OCCSUM" "$DBSUM"

echo "== 4. CRUD（仓库表全流程）=="
NEWID=$($CURL $AUTH -H "Content-Type: application/json" -d '{"name":"测试仓库X","remark":"集成测试"}' $BASE/api/storage | jval "['data']['id']")
[ -n "$NEWID" ] && ok "新增仓库 id=$NEWID" || no "新增失败"
GOTNAME=$($CURL $AUTH $BASE/api/storage/$NEWID | jval "['data']['name']")
assert_eq "查询新增仓库" "$GOTNAME" "测试仓库X"
$CURL $AUTH -X PUT -H "Content-Type: application/json" -d "{\"id\":$NEWID,\"name\":\"测试仓库X2\",\"remark\":\"改\"}" $BASE/api/storage/$NEWID >/dev/null
UPD=$($CURL $AUTH $BASE/api/storage/$NEWID | jval "['data']['name']")
assert_eq "修改仓库名生效" "$UPD" "测试仓库X2"
DELCODE=$($CURL $AUTH -o /dev/null -w "%{http_code}" -X DELETE $BASE/api/storage/$NEWID)
assert_eq "删除仓库 HTTP200" "$DELCODE" "200"
GONE=$($CURL $AUTH $BASE/api/storage/$NEWID | jval "['code']")
assert_eq "删除后查询返回 404" "$GONE" "404"

echo "== 5. 出入库（真实改库存 + 流水 + 库位同步）=="
B4=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT count FROM goods WHERE id=13" 2>/dev/null)
$CURL $AUTH -H "Content-Type: application/json" -d '{"goodsId":13,"count":50,"remark":"test in"}' $BASE/api/inout/in >/dev/null
AFTIN=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT count FROM goods WHERE id=13" 2>/dev/null)
assert_eq "入库后库存 +50" "$AFTIN" "$((B4+50))"
FAILOUT=$($CURL $AUTH -H "Content-Type: application/json" -d '{"goodsId":13,"count":999999}' $BASE/api/inout/out | jval "['code']")
assert_eq "超量出库被拒" "$FAILOUT" "500"
$CURL $AUTH -H "Content-Type: application/json" -d '{"goodsId":13,"count":30,"remark":"test out"}' $BASE/api/inout/out >/dev/null
AFTOUT=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT count FROM goods WHERE id=13" 2>/dev/null)
assert_eq "出库后库存 -30" "$AFTOUT" "$((B4+20))"
LSSUM=$(mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -N -e "SELECT COALESCE(SUM(count),0) FROM location_stock WHERE goods_id=13" 2>/dev/null)
assert_eq "库位存货与货物库存一致" "$LSSUM" "$AFTOUT"
# 还原
mysql -uwms -pwms123456 -h127.0.0.1 ahut_base -e "DELETE FROM record WHERE remark IN('test in','test out'); UPDATE goods SET count=$B4 WHERE id=13; UPDATE location_stock SET count=$B4 WHERE goods_id=13;" 2>/dev/null
ok "测试数据已还原"

echo ""
echo "==================== 结果：PASS=$PASS  FAIL=$FAIL ===================="
[ "$FAIL" -eq 0 ] && echo "✅ 全部通过" || echo "❌ 有失败项"
exit $FAIL
