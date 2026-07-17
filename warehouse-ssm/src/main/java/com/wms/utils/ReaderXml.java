package com.wms.utils;

import org.dom4j.Document;
import org.dom4j.DocumentException;
import org.dom4j.Node;
import org.dom4j.io.SAXReader;

import java.io.InputStream;
import java.util.ArrayList;
import java.util.List;

/** 读取 URL_List.xml，得到登录过滤器的放行白名单（对应参考项目 ReaderXml）。 */
public class ReaderXml {
    private static Document document;
    static {
        InputStream in = ReaderXml.class.getClassLoader().getResourceAsStream("/URL_List.xml");
        SAXReader reader = new SAXReader();
        try {
            document = reader.read(in);
        } catch (DocumentException e) {
            throw new RuntimeException(e);
        }
    }

    public static List<String> getList() {
        List<String> list = new ArrayList<>();
        List<Node> nodes = document.selectNodes("/list/item");
        for (Node node : nodes) list.add(node.getText());
        return list;
    }
}
