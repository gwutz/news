
gnome_news_sources = [
    'main.vala',
    'gnome-news-application.vala',
    'gnome-news-application-window.vala',
    'gnome-news-tracker.vala',
    'gnome-news-controller.vala',
    'gnome-news-post.vala',
    'gnome-news-article-list.vala',
    'gnome-news-article-view.vala',
    gnome_news_resources
]

executable ('gnome-news',
            gnome_news_sources,
            dependencies: [glib, gobject, gio, gtk, sparql, webkit],
            vala_args:['--target-glib=2.38', '--gresources=' + meson.source_root () + '/data/gnome-news-resource.xml'],
            install: true
            )
