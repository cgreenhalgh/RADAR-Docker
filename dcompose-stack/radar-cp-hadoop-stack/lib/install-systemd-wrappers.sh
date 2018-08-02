cd "$(dirname "${BASH_SOURCE[0]}")/.."

. lib/util.sh

check_command_exists systemctl

copy_template_if_absent /etc/systemd/system/radar-docker.service lib/systemd/radar-docker.service.template
copy_template_if_absent /etc/systemd/system/radar-output.service lib/systemd/radar-output.service.template
copy_template_if_absent /etc/systemd/system/radar-output.timer lib/systemd/radar-output.timer.template
copy_template_if_absent /etc/systemd/system/radar-check-health.service lib/systemd/radar-check-health.service.template
copy_template_if_absent /etc/systemd/system/radar-check-health.timer lib/systemd/radar-check-health.timer.template
copy_template_if_absent /etc/systemd/system/radar-renew-certificate.service lib/systemd/radar-renew-certificate.service.template
copy_template_if_absent /etc/systemd/system/radar-renew-certificate.timer lib/systemd/radar-renew-certificate.timer.template

inline_variable 'WorkingDirectory=' "$PWD" /etc/systemd/system/radar-docker.service
inline_variable 'ExecStart=' "$PWD/bin/radar-docker foreground" /etc/systemd/system/radar-docker.service

inline_variable 'WorkingDirectory=' "$PWD/hdfs" /etc/systemd/system/radar-output.service
inline_variable 'ExecStart=' "$PWD/bin/hdfs-restructure-process" /etc/systemd/system/radar-output.service

inline_variable 'WorkingDirectory=' "$PWD" /etc/systemd/system/radar-check-health.service
inline_variable 'ExecStart=' "$PWD/bin/radar-docker health" /etc/systemd/system/radar-check-health.service

inline_variable 'WorkingDirectory=' "$DIR" /etc/systemd/system/radar-renew-certificate.service
inline_variable 'ExecStart=' "$PWD/bin/radar-docker cert-renew" /etc/systemd/system/radar-renew-certificate.service

sudo systemctl daemon-reload
sudo systemctl enable radar-docker
sudo systemctl enable radar-output.timer
sudo systemctl enable radar-check-health.timer
sudo systemctl enable radar-renew-certificate.timer
sudo systemctl start radar-docker
sudo systemctl start radar-output.timer
sudo systemctl start radar-check-health.timer
sudo systemctl start radar-renew-certificate.timer