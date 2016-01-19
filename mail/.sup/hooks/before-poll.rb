if (@last_fetch || Time.at(0)) < Time.now - 120
  say "Running offlineimap..."
  system "offlineimap -o -u quiet &> /dev/null"
  say "Finished offlineimap run."
  @last_fetch = Time.now
end
