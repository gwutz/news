gnome = import ('gnome')

news_resources = gnome.compile_resources ('news_resource', 'news-resource.xml', source_dir: '.', c_name: 'news')

install_data('org.gnome.News.desktop',
    install_dir : join_paths('share', 'applications'))

subdir('icons')
