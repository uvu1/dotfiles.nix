{ ... }:

{
  services.flatpak = {
    enable = true;

    packages = [
      "com.slack.Slack"
      "com.spotify.Client"
    ];

    update.auto = {
      enable = true;
      onCalendar = "weekly";
    };
  };
}
