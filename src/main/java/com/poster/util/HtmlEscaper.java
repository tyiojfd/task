package com.poster.util;

/** Minimal HTML text/attribute escaping for JSP scriptlet output. */
public final class HtmlEscaper {

    private HtmlEscaper() {
    }

    public static String escape(String value) {
        if (value == null) {
            return "";
        }
        return value.replace("&", "&amp;")
                .replace("<", "&lt;")
                .replace(">", "&gt;")
                .replace("\"", "&quot;")
                .replace("'", "&#39;");
    }
}
