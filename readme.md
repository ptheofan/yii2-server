# Default Configuration

Default embedded configuration can be found in `/root`. To override any mount point, the recommended files can be found in the `config` folder.


# Extensions

Modify and enable/disable php extensions by mounting the config/php and adjusting the ini files. To completely disable an extesion simply comment out the first line like this
```ini
; extension=xdebug.so
```

Mount Targets

- Yii2 App Source Code `/app`
- Composer Cache `/root/.composer/cache`
- Github Auth `/root/.composer/auth.json`
- Nginx Configuration `/config/nginx`
- PHP ini files `/usr/local/etc/php`
- Bashrc of your choice `/root/.bashrc`