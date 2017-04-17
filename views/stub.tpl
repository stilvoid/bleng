<article class="card">
    <a href="/{{article["path"]}}/">
        {{article["title"]}}
    </a>
    &nbsp;
    <time>
        {{datetime.datetime.utcfromtimestamp(int(article["timestamp"])).strftime("%Y-%m-%d")}}
    </time>
    <br />
    <div class="chips">
        % for tag in sorted(article["tags"]):
        <span class="chip">{{tag}}</span>
        % end
    </div>
</article>
