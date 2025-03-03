#!/usr/bin/env elixir

Mix.install([:req])

# OAuth 2.0 Credentials from Google Cloud Console
cs =
  "client_secret.json"
  |> File.read!()
  |> Jason.decode!()
  |> Map.get("installed")
  |> tap(&IO.inspect(&1))

# Authorization Request Details
query_string =
  URI.encode_query(%{
    client_id: cs["client_id"],
    redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
    response_type: :code,
    scope: "https://www.googleapis.com/auth/calendar.readonly",
    access_type: :offline
  })

# Open in browser
url = "https://accounts.google.com/o/oauth2/v2/auth?#{query_string})}"
System.cmd("open", [url])

# The one-time Code returned from the previous step
code = IO.gets("code> ") |> String.trim()

# Tokens
creds =
  Req.post!("https://oauth2.googleapis.com/token",
    form: [
      client_id: cs["client_id"],
      client_secret: cs["client_secret"],
      code: code,
      redirect_uri: "urn:ietf:wg:oauth:2.0:oob",
      grant_type: "authorization_code"
    ]
  ).body
  |> tap(&IO.inspect(&1))
