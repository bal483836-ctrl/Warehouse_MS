package com.wms.controller;

import com.wms.common.Md5Util;
import com.wms.common.Result;
import com.wms.entity.SysUser;
import com.wms.repo.SysUserRepo;
import com.wms.security.TokenStore;
import jakarta.servlet.http.HttpServletRequest;
import org.springframework.web.bind.annotation.*;

import java.util.HashMap;
import java.util.Map;
import java.util.Optional;

@RestController
@RequestMapping("/api/auth")
public class AuthController {

    private final SysUserRepo userRepo;
    private final TokenStore tokenStore;

    public AuthController(SysUserRepo userRepo, TokenStore tokenStore) {
        this.userRepo = userRepo;
        this.tokenStore = tokenStore;
    }

    public record LoginReq(String number, String password) {}

    @PostMapping("/login")
    public Result<Map<String, Object>> login(@RequestBody LoginReq req) {
        if (req.number() == null || req.password() == null)
            return Result.fail("账号或密码不能为空");
        Optional<SysUser> opt = userRepo.findByNumber(req.number().trim());
        if (opt.isEmpty()) return Result.fail("账号不存在");
        SysUser u = opt.get();
        if (u.getDelFlag() != null && u.getDelFlag() == 1) return Result.fail("账号已删除");
        if (u.getLocked() != null && u.getLocked() == 1) return Result.fail("账号已被锁定");
        String hashed = Md5Util.hashPassword(req.password(), u.getSalt());
        if (!hashed.equalsIgnoreCase(u.getPassword())) return Result.fail("密码错误");

        String token = tokenStore.issue(new TokenStore.Principal(u.getId(), u.getName(), u.getNumber()));
        Map<String, Object> data = new HashMap<>();
        data.put("token", token);
        data.put("user", safeUser(u));
        return Result.ok(data);
    }

    @PostMapping("/logout")
    public Result<Void> logout(HttpServletRequest req) {
        String token = req.getHeader("token");
        if (token == null) token = req.getHeader("Authorization");
        tokenStore.revoke(token);
        return Result.ok();
    }

    @GetMapping("/me")
    public Result<Object> me(HttpServletRequest req) {
        TokenStore.Principal p = (TokenStore.Principal) req.getAttribute("principal");
        if (p == null) return Result.fail(401, "未登录");
        return userRepo.findById(p.userId()).<Object>map(this::safeUser)
                .map(Result::ok).orElseGet(() -> Result.fail(401, "用户不存在"));
    }

    public record ChangePwdReq(String oldPassword, String newPassword) {}

    /** 修改密码：校验原密码，重新按 salt 散列保存 */
    @PostMapping("/changePassword")
    public Result<Void> changePassword(@RequestBody ChangePwdReq req, HttpServletRequest http) {
        TokenStore.Principal p = (TokenStore.Principal) http.getAttribute("principal");
        if (p == null) return Result.fail(401, "未登录");
        if (req.oldPassword() == null || req.newPassword() == null || req.newPassword().trim().length() < 6)
            return Result.fail("新密码至少 6 位");
        SysUser u = userRepo.findById(p.userId()).orElse(null);
        if (u == null) return Result.fail("用户不存在");
        if (!Md5Util.hashPassword(req.oldPassword(), u.getSalt()).equalsIgnoreCase(u.getPassword()))
            return Result.fail("原密码错误");
        u.setPassword(Md5Util.hashPassword(req.newPassword().trim(), u.getSalt()));
        userRepo.save(u);
        return Result.ok();
    }

    private Map<String, Object> safeUser(SysUser u) {
        Map<String, Object> m = new HashMap<>();
        m.put("id", u.getId());
        m.put("name", u.getName());
        m.put("number", u.getNumber());
        m.put("age", u.getAge());
        m.put("sex", u.getSex());
        m.put("phone", u.getPhone());
        return m;
    }
}
