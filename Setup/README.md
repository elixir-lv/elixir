# Setup

Open the local hosts
```sh
sudo nano /etc/hosts
```

Add this line
```sh
127.0.0.1	elixir.local
```

Enable this page in NGINX
```sh
sudo ln -s /home/j/www/github/elixir/front/elixir-front.conf /etc/nginx/sites-enabled/elixir-front.conf
sudo systemctl restart nginx.service
```
Open in the browser [elixir.local](http://elixir.local).
