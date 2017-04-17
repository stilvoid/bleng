<?xml version="1.0" encoding="UTF-8" ?>

% from datetime import datetime
% rss_date = lambda timestamp: datetime.utcfromtimestamp(int(timestamp)).strftime("%a, %d %b %Y %T GMT")

<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <atom:link href="{{root}}/rss.xml" rel="self" type="application/rss+xml" />
        <title>Offend.me.uk</title>
        <description>RSS feed for {{root}}</description>
        <link>{{root}}/</link>
        <lastBuildDate>{{rss_date(datetime.timestamp(datetime.now()))}}</lastBuildDate>
        <language>en-gb</language>

        % for article in articles[:10]:
            <item>
                <title>{{article["title"]}}</title>
                <link>{{root}}/{{article["path"]}}/</link>
                <pubDate>{{rss_date(article["timestamp"])}}</pubDate>
                <description>
                    <![CDATA[{{!article["content"]}}]]>
                </description>
            </item>
        % end
    </channel>
</rss>
