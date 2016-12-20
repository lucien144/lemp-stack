<?php
function adminer_object() {
    // required to run any plugin
    include_once "./plugins/plugin.php";

    // autoloader
    foreach (glob("plugins/*.php") as $filename) {
        include_once "./$filename";
    }

    $plugins = array(
        // specify enabled plugins here
        new AdminerColors(array(
            # specify as many servers as you want
            'adminer.dev' => '#009245',
        )),
    );

    return new AdminerPlugin($plugins);
}

// include original Adminer or Adminer Editor
include "./latest.php";