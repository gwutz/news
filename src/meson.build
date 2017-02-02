
gnome_news_sources = [
    'main.vala',
    'gnome-news-controller.vala',
    'gnome-news-tracker.vala',
    'gnome-news-post.vala',
    'gnome-news-feed.vala',
    'ui/gnome-news-application.vala',
    'ui/gnome-news-application-window.vala',
    'ui/gnome-news-article-list.vala',
    'ui/gnome-news-article-box.vala',
    'ui/gnome-news-article-view.vala',
    'ui/gnome-news-widget-factory.vala',
    'ui/gnome-news-feed-view.vala',
    'ui/gnome-news-updateable.vala',
    'worker/gnome-news-company.vala',
    'worker/gnome-news-worker.vala',
    'worker/gnome-news-image-loader.vala',
    gnome_news_resources
]

executable ('gnome-news',
            gnome_news_sources,
            dependencies: [glib, gobject, gio, gtk, sparql, webkit],
            vala_args:['--target-glib=2.38', '--gresources=' + meson.source_root () + '/data/gnome-news-resource.xml'],
            install: true
            )
