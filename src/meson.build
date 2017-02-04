
gnome_news_sources = [
    'main.vala',
    'controller.vala',
    'tracker.vala',
    'post.vala',
    'feed.vala',
    'ui/application.vala',
    'ui/application-window.vala',
    'ui/article-list.vala',
    'ui/article-box.vala',
    'ui/article-view.vala',
    'ui/new-view.vala',
    'ui/feed-view.vala',
    'ui/star-view.vala',
    'ui/updateable.vala',
    'ui/switchable.vala',
    'worker/company.vala',
    'worker/worker.vala',
    'worker/image-loader.vala',
    gnome_news_resources
]

executable ('gnome-news',
            gnome_news_sources,
            dependencies: [glib, gobject, gio, gtk, sparql, webkit],
            vala_args:['--target-glib=2.38', '--gresources=' + meson.source_root () + '/data/gnome-news-resource.xml'],
            install: true
            )
