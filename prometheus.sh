#качаем дистрибутив Prometheus
wget https://github.com/prometheus/prometheus/releases/download/v2.45.0/prometheus-2.45.0.linux-amd64.tar.gz
#создаем директорию куда переместим дистрибутив
mkdir prometheus
#переносим дистрибутив в директорию
mv prometheus-2.45.0.linux-amd64.tar.gz prometheus
#распаковываем Prometheus
tar -xvf prometheus-2.45.0.linux-amd64.tar.gz
#качаем node_exporter
wget https://github.com/prometheus/node_exporter/releases/download/v1.6.0/node_exporter-1.6.0.linux-amd64.tar.gz
#разархивируем node_exporter
tar -xvf node_exporter-1.6.0.linux-amd64.tar.gz
#создаем пользователя для запуска Prometheus без возможности под ним залогиниться, а так же без домашней папки (в качестве безопасности)
useradd --no-create-home --shell /usr/bin/false prometheus
#аналогично для node_exporter
useradd --no-create-home --shell /usr/sbin/nologin node_exporter
#переходим в папку prometheus
cd ~mamaev/prometheus/prometheus-2.45.0.linux-amd64/
#создаем директории для Prometheus
mkdir -m 755 {/etc/, /var/lib/} prometheus
#переносим prometheus в папку подготовленную ранее с переносом прав на файл
rsync --chown=prometheus:prometheus -arvP consoles console_libraries /etc/prometheus
#переносим promtool
rsync --chown=prometheus:prometheus -arvuP prometheus promtool /usr/local/bin/
#ставим права для пользователя Prometheus, если пользовались переносом файлов с помощью cp
chown -v -R prometheus: /etc/prometheus
#аналогично делаем с node_exporterom
rsync --chown=node_exporter:node_exporter -arvuP node_exporter /usr/local/bin
#даем права пользователю на еще 1 папку
chown -v -R prometheus: /var/lib/prometheus
#чтобы работал Prometheus
sudo -u prometheus  /usr/local/bin/prometheus --config.file /etc/prometheus/prometheus.yml --storage.tsdb.path /var/lib/prometheus --web.console.templates /etc/prometheus/consoles --web.console.libraries /etc/prometheus/sonsole_libraries
#переходим в домашнюю директорию и в Prometheus
cd mamaev/otus2
#закидываем готовые файлы по пути /etc/systemd/systemd
sudo rsync -abvuP node_exporter.service prometheus.service /etc/systemd/system
#перезапускаем systemd
systemctl daemon-reload
#запускаем Prometheus и node_exporter
systemctl start prometheus.service
#Переходим в директорию Prometheus
cd /etc/prometheus/
##устанавливаем пакет, чтобы можно было ходить по https
#sudo apt-get install -y apt-transport-https
#sudo apt-get install -y softwaer-properties-common wget
##получаем ключ для доверительных отношений с репозиторием графаны
#sudo wget -q -O /usr/share/keyrings/grafana.key https://apt/grafana.com/gpg.key
##отправляем данные на сайт, что нам нужен deb пакет
#echo "deb [signed-by=/usr/share/keyrings/grafana.key] https://apt/grafana.com stable main" | sudo tee -a /etc/apt/sources.list.d/grafana.list
##обновляем информацию о репозиториях
#sudo apt-get update
#устанавливаем Grafana
sudo apt-get install -y adduser libfontconfig1
#качаем grafana
wget https://dl.grafana.com/oss/release/grafana_10.0.1_amd64.deb
#устанавливаем grafana
sudo dpkg -i grafana_10.0.1_amd64.deb