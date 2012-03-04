every 2.minutes do
  runner "Client.check_statuses"
end
every 5.minutes do
  runner "Site.take_snapshots"
end