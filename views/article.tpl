<article class="card">
    <h1>{{article["title"]}}</h1>

    {{!article["content"]}}

    <p>
        <a href="/{{article["path"]}}/">Permalink</a>
        &nbsp;
        <time>
            {{datetime.datetime.utcfromtimestamp(int(article["timestamp"])).strftime("%Y-%m-%d")}}
        </time>
    </p>

    <div>
        % for tag in sorted(article["tags"]):
        <span class="chip">{{tag}}</span>
        % end
    </div>
</article>
