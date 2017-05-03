<%
    # A convenience function for making dates pretty
    import datetime
    def format_date(timestamp):
        return datetime.datetime.utcfromtimestamp(int(timestamp)).strftime("%Y-%m-%d")
    end
%>
<!DOCTYPE html>
<html lang="en">
	<head>
        <meta charset="utf-8">
        <meta http-equiv="X-UA-Compatible" content="IE=edge">
        <meta name="viewport" content="width=device-width, initial-scale=1.0">
        <meta name="keywords" content="{{",".join(page["tags"])}}" />
        <meta name="description" content="{{page["title"]}}" />

		<title>{{page["title"]}}</title>
	</head>

	<body>
        <main>
            <h1>{{page["title"]}}</h1>

            % if page["content"]:
            <p>
                {{!page["content"]}}
            </p>
            % end

            <p>
                <time>{{format_date(page["timestamp"])}}</time>
                -
                <a href="{{config["root"]}}{{page["url"]}}">Permalink</a>
            </p>

            <p>
            % if page["tags"]:
                % for tag in page["tags"]:
                    <span>{{tag}}</span>
                % end
            % end
            </p>
        </main>

        % if other_articles:
        <nav>
            % for article in other_articles:
            <p>
                <a href="{{article["url"]}}">
                    {{article["title"]}}
                    -
                    <time>{{format_date(article["timestamp"])}}</time>
                    % if article["tags"]:
                    -
                        % for tag in sorted(article["tags"]):
                        <span>{{tag}}</span>
                        % end
                    % end
                </a>
            </p>
            % end
        </nav>
        %end
	</body>
</html>
