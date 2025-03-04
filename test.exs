#!/usr/bin/env elixir

Mix.install([:req])

# OAuth 2.0 Credentials from Google Cloud Console
# security add-generic-password -a google -s calendar-audit -w $(cat client-secret.json)
creds =
  System.cmd("security", ~w(find-generic-password -a google -s calendar-token -w))
  |> elem(0)
  |> Jason.decode!()

# API Request
# curl -H "Authorization: Bearer YOUR_ACCESS_TOKEN" "https://www.googleapis.com/calendar/v3/calendars/primary/events"
x =
  Req.get!("https://www.googleapis.com/calendar/v3/calendars/primary/events",
    auth: {:bearer, creds["access_token"]}
  ).body

File.write("events.bet", :erlang.term_to_binary(x))
File.write("events.json", Jason.encode!(x))
