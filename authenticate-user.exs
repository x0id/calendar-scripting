#!/usr/bin/env elixir

Mix.install([:req])

# OAuth 2.0 Credentials from Google Cloud Console
# security add-generic-password -U -a google -s calendar-audit -w $(cat client-secret.json)
cs =
  System.cmd("security", ~w(find-generic-password -a google -s calendar-audit -w))
  |> elem(0)
  |> Jason.decode!()
  |> Map.get("installed")

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
url = "https://accounts.google.com/o/oauth2/v2/auth?#{query_string}"
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
  |> Jason.encode!()

System.cmd("security", ~w(add-generic-password -U -a google -s calendar-token -w) ++ [creds])
