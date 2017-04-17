<?xml version="1.0" encoding="UTF-8" ?>

% from datetime import datetime
% rss_date = lambda timestamp: datetime.utcfromtimestamp(int(timestamp)).strftime("%a, %d %b %Y %T GMT")

<rss version="2.0" xmlns:atom="http://www.w3.org/2005/Atom">
    <channel>
        <atom:link href="https://engledow.me/rss.xml" rel="self" type="application/rss+xml" />
        <title>Engledow.me</title>
        <description>RSS feed for Engledow.me</description>
        <link>https://engledow.me/</link>
        <lastBuildDate>{{rss_date(datetime.timestamp(datetime.now()))}}</lastBuildDate>
        <language>en-gb</language>
        <image>
            <url>https://static.offend.me.uk/media/images/me.png</url>
            <title>Engledow.me</title>
            <link>https://engledow.me/</link>
            <width>32</width>
            <height>32</height>
        </image>

        % for article in articles[:10]:
            <item>
                <title>{{article["title"]}}</title>
                <author>steve@engledow.me (Steve Engledow)</author>
                <guid isPermaLink="true">https://engledow.me/{{article["path"]}}/</guid>
                <link>https://engledow.me/{{article["path"]}}/</link>
                <pubDate>{{rss_date(article["timestamp"])}}</pubDate>
                <description>
                    <![CDATA[{{!article["content"]}}]]>
                </description>
            </item>
        % end
    </channel>
</rss>
