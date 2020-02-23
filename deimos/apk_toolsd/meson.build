pkgc = import('pkgconfig')

apk_d_src = [
    'apk_applet.d',
    'apk_archive.d',
    'apk_blob.d',
    'apk_database.d',
    'apk_defines.d',
    'apk_hash.d',
    'apk_io.d',
    'apk_package.d',
    'apk_print.d',
    'apk_provider_data.d',
    'apk_solver.d',
    'apk_solver_data.d',
    'apk_version.d',
]

pkgc.generate(
    name: 'apk-toolsd',
    subdirs: 'd/apk-toolsd',
    requires: apk_tools_dep,
    version: meson.project_version(),
    description: 'D bindings for the Alpine Package Keeper.',
)

install_headers(
    apk_d_src,
    subdir: 'd/apk-toolsd/deimos/apk_toolsd',
)