<!DOCTYPE html>
<html lang="en">
	<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="{{",".join(tags)}}" />
        <meta name="description" content="Engledow.me: {{title[0].upper() + title[1:]}}" />

		<title>Engledow.me: {{title[0].upper() + title[1:]}}</title>

        <link rel="icon" href="https://static.offend.me.uk/media/images/me.ico" />
        <link rel="alternate" type="application/rss+xml" href="/rss.xml" />
        <link rel="stylesheet" href="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.9.1/styles/default.min.css">
        <link rel="stylesheet" href="https://static.offend.me.uk/media/css/style.engledow.css">
	</head>

	<body>
		<header>
			<nav>
				<div class="buttons">
					<a href="/"><img width="28" height="28" src="https://static.offend.me.uk/media/images/me.png" alt="Home" /></a>
					<a href="https://uk.linkedin.com/in/sengledow"><img src="https://static.offend.me.uk/media/images/linkedin.png" alt="Twitter" /></a>
					<a href="https://twitter.com/stilvoid"><img src="https://static.offend.me.uk/media/images/twitter.png" alt="Twitter" /></a>
					<a href="https://github.com/stilvoid"><img src="https://static.offend.me.uk/media/images/github.png" alt="GitHub" /></a>
					<a href="/rss.xml"><img src="https://static.offend.me.uk/media/images/rss.png" alt="RSS Feed" /></a>
				</div>
			</nav>

			<div id="copyright">
                All content &copy; 2016
                Steve Engledow.
                All views my own.
			</div>
		</header>

		% if blurb or articles:
		<main id="articles">
			<%
                MAX = 5

				import datetime

                if blurb:
                    articles = [blurb] + articles
                end

				last_month = None
				for article in articles[:MAX]:
                    current_month = datetime.datetime.utcfromtimestamp(int(article["timestamp"])).strftime("%B %Y")

					if len(articles) > 1 and last_month != current_month:
						last_month = current_month
						%>
						<div class="date">
							{{current_month}}
						</div>
						<%
					end

					include("article.tpl", article=article)
				end

                if len(articles) > MAX:
                    %>
                        <div class="date">Older posts</div>
                    <%

                    for article in articles[MAX:]:
                        include("stub.tpl")
                    end
                end
            %>
        </main>
		% end

        <script src="https://code.jquery.com/jquery-2.1.1.min.js"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/highlight.js/8.9.1/highlight.min.js"></script>

        <script>
            hljs.initHighlightingOnLoad();
        </script>
	</body>
</html>
