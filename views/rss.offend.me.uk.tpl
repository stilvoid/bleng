<?xml version="1.0" encoding="UTF-8" ?>

% from datetime import datetime
% rss_date = lambda timestamp: datetime.utcfromtimestamp(int(timestamp)).strftime("%a, %d %b %Y %T GMT")

<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <atom:link href="https://offend.me.uk/rss.xml" rel="self" type="application/rss+xml" />
        <title>Offend.me.uk</title>
        <description>RSS feed for Offend.me.uk</description>
        <link>https://offend.me.uk/</link>
        <lastBuildDate>{{rss_date(datetime.timestamp(datetime.now()))}}</lastBuildDate>
        <language>en-gb</language>
        <image>
            <url>https://static.offend.me.uk/media/images/me.png</url>
            <title>Offend.me.uk</title>
            <link>https://offend.me.uk/</link>
            <width>32</width>
            <height>32</height>
        </image>

        % for article in articles[:10]:
            <item>
                <title>{{article["title"]}}</title>
                <author>steve@offend.me.uk (Steve Engledow)</author>
                <guid isPermaLink="true">https://offend.me.uk/{{article["path"]}}/</guid>
                <link>https://offend.me.uk/{{article["path"]}}/</link>
                <pubDate>{{rss_date(article["timestamp"])}}</pubDate>
                <description>
                    <![CDATA[{{!article["content"]}}]]>
                </description>
            </item>
        % end
    </channel>
</rss>
