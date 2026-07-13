package com.poster.util;

import org.junit.jupiter.api.Test;

import static org.junit.jupiter.api.Assertions.assertEquals;

class HtmlEscaperTest {

    @Test
    void escapesHtmlTextAndAttributeCharacters() {
        assertEquals("&lt;script&gt;alert(&#39;x&#39;)&lt;/script&gt; &amp; &quot;ok&quot;",
                HtmlEscaper.escape("<script>alert('x')</script> & \"ok\""));
    }

    @Test
    void returnsEmptyTextForNull() {
        assertEquals("", HtmlEscaper.escape(null));
    }
}
