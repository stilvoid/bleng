<%
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

        <main>
            <h1>{{title}}</h1>

            % if content:
            <p>
                {{!content}}
            </p>
            % end

            <p>
            % if tags:
                % for tag in tags:
                    <span>{{tag}}</span>
                % end
            % end
            </p>
        </main>

        % if articles:
        <nav>
            % for article in articles:
            <p>
                <a href="{{article["url"]}}">
                    {{article["title"]}}
                    -
                    <time>{{format_date(article)}}</time>
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
