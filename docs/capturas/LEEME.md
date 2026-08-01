# Capturas del espejo

Hechas con Chromium headless en un contenedor de la misma red de Docker.
Receta, porque tiene tres trampas:

```bash
# 1. El espejo redirige al dominio canonico. Cambiarlo temporalmente:
#    UPDATE psjy_shop_url SET domain='web', domain_ssl='web';
#    UPDATE psjy_configuration SET value='web' WHERE name IN ('PS_SHOP_DOMAIN','PS_SHOP_DOMAIN_SSL');
# 2. MSYS_NO_PATHCONV=1, o Git Bash convierte /out en C:/Program Files/Git/out
# 3. --headless=old  ← con el headless nuevo se queda colgado sin escribir nada
MSYS_NO_PATHCONV=1 docker run --rm --network importtools_default \
  -v "$(pwd -W)/tmp-shots:/out" --user root --entrypoint chromium-browser \
  zenika/alpine-chrome --headless=old --no-sandbox --disable-gpu \
  --disable-dev-shm-usage --hide-scrollbars \
  --virtual-time-budget=8000 --window-size=1280,1000 \
  --screenshot=/out/home.png "http://web/"
```

Y calentar la cache antes con un curl: la primera peticion tras vaciarla tarda
unos 50 s y la captura sale en blanco.

⚠️ Al terminar, devolver el dominio a `localhost:8080`.
