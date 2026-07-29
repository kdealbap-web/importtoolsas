# Imagen web: PHP 8.5 + Apache con extensiones que exige PrestaShop 9.1
# (si 'php:8.5-apache' aún no estuviera disponible al construir, cambia el tag a 8.4-apache)
#
# Dos cosas que rompen el build si se cambian:
#
# 1) NO incluir 'opcache' en docker-php-ext-install. En php:8.5-apache el Zend OPcache
#    ya viene compilado estáticamente (aparece en `php -m`) y no hay fuentes en
#    /usr/src/php/ext/opcache, así que configure no compila nada y `make install` aborta
#    con "cp: cannot stat 'modules/*'" → "make: *** [install-modules] Error 1".
#    Los ajustes de opcache de config/php.ini se aplican igual.
#
# 2) Compilar con -j1. Con -j"$(nproc)" libtool corre en paralelo sobre el mismo
#    directorio y aparece "mkdir: cannot create directory '.libs': File exists".
#    OJO: el build medido con -j1 tardó 10.590 s (~2,9 h), casi todo en 'intl'.
#    Es un coste de UNA vez: la imagen queda en caché y solo se reconstruye si se
#    cambia este Dockerfile. Si alguna vez hay que reconstruir con prisa, se puede
#    probar -j4 (más rápido, pero puede reaparecer la carrera de .libs de forma
#    intermitente y habría que reintentar).
FROM php:8.5-apache

RUN apt-get update && apt-get install -y --no-install-recommends \
      libfreetype6-dev libjpeg62-turbo-dev libpng-dev libicu-dev \
      libzip-dev libxml2-dev libcurl4-openssl-dev unzip \
  && docker-php-ext-configure gd --with-freetype --with-jpeg \
  && docker-php-ext-install -j1 gd intl pdo_mysql mysqli zip soap exif bcmath \
  && a2enmod rewrite headers \
  && printf '<Directory /var/www/html>\n    AllowOverride All\n    Require all granted\n</Directory>\n' \
       > /etc/apache2/conf-available/prestashop.conf \
  && a2enconf prestashop \
  && rm -rf /var/lib/apt/lists/*

COPY config/php.ini /usr/local/etc/php/conf.d/zz-prestashop.ini
