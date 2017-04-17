<!DOCTYPE html>
<html lang="en">
	<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="google-site-verification" content="JnTcLzHMUCpJ_3ntR0I4U9HrOx_3bB1qtA0uS49ODhM" />
        <meta name="keywords" content="{{",".join(tags)}}" />
        <meta name="description" content="Offend Me: {{title[0].upper() + title[1:]}}" />

		<title>Offend Me: {{title[0].upper() + title[1:]}}</title>

        <link rel="icon" href="https://static.offend.me.uk/media/images/me.ico" />
        <link rel="alternate" type="application/rss+xml" href="/rss.xml" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.9.1/styles/default.min.css">
        <link rel="stylesheet" href="https://static.offend.me.uk/media/css/style.css">
	</head>

    <%
        # Prepare the menu

        orig_url = url

        menu = []
        part = None
        path = ""

        while dirs:
            if url:
                part, url = url[0], url[1:]
            end

            menu += [[(dir, "{}/{}/".format(path, dir), dir == part) for dir in sorted(dirs.keys())]]

            if part in dirs and dirs[part]:
                dirs = dirs[part]
                path = "{}/{}".format(path, part)
            else:
                break
            end
        end

        url = orig_url
    %>

	<body>
        <div class="container">
            <div>
                <a href="/">Home</a>
            </div>

            <%
                for name, path, active in menu[0]:
            %>
                    <div>
                        <a {{!'class="active" ' if active else ""}}href="{{path}}">{{name[0].upper() + name[1:]}}</a>
                    </div>
        <%
                end
            %>
        </div>

        <%
            if not blurb and len(articles) == 1:
                blurb = articles[0]
                articles = []
            end
        %>

        % if blurb:
        <div class="container">
            <article id="blurb">
                <h1 class="card-title">{{blurb["title"]}}</h1>

                {{!blurb["content"]}}
            </article>
        </div>
        % end

        % if len(menu) > 1:
        <div class="container">
            <%
                for row in menu[1:]:
                    for name, path, active in row:
            %>
                    <div>
                        <a {{!'class="active" ' if active else ""}}href="{{path}}">{{name[0].upper() + name[1:]}}</a>
                    </div>
        <%
                    end
                end
            %>
        </div>
        %end

        % if articles and url:  # Hack to stop the blogroll
        <div class="container">
            <%
                import datetime

                for article in articles:
                %>
                <a class="card" href="/{{article["path"]}}/">
                    {{article["title"]}}
                    <br />
                    <time>
                        {{datetime.datetime.utcfromtimestamp(int(article["timestamp"])).strftime("%Y-%m-%d")}}
                    </time>
                    <br />
                    <div class="chips">
                        % for tag in sorted(article["tags"]):
                        <span class="chip">{{tag}}</span>
                        % end
                    </div>
                </a>
                <%
                end
            %>
        </div>
        % end

        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.9.1/highlight.min.js"></script>
        <script>
            hljs.initHighlightingOnLoad();
        </script>
	</body>
</html>
