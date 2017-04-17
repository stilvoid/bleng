<%
    # For the simplicity of this example template, we'll merge the blurb with the other articles
    if blurb:
        articles = [blurb] + articles
    end

    # A convenience function for making dates pretty
    import datetime
    def format_date(article):
        return datetime.datetime.utcfromtimestamp(int(article["timestamp"])).strftime("%Y-%m-%d")
    end
%>
<!DOCTYPE html>
<html lang="en">
	<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="{{",".join(tags)}}" />
        <meta name="description" content="{{title}}" />

		<title>{{title}}</title>
	</head>

	<body>
        <p>
        <%
            import json
        %>
        {{json.dumps(articles, indent=4)}}
        </p>

        % for article in articles:
        <article id="blurb">
            <h1>{{article["title"]}}</h1>

            {{!article["content"]}}

            <p>
                <strong>Date:</strong>
                <time>{{format_date(article)}}</time>
            </p>

            <p>
                <strong>Tags:</strong>
                % for tag in sorted(article["tags"]):
                <span>{{tag}}</span>
                % end
            </p>
        </article>
        % end
	</body>
</html>
