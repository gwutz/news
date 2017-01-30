/*
 * gnome-news-article-list.vala
 * This file is part of gnome-news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome-news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome-news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome-news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GnomeNews {
    [GtkTemplate (ui = "/org/gnome/News/ui/articlerow.ui")]
    public class ArticleList : Gtk.Box {
        public Post post { get; set; }
        
        [GtkChild (name = "title")]
        private Gtk.Label title;
        
        [GtkChild (name = "author")]
        private Gtk.Label author;
        
        public ArticleList (Post p) {
            this.post = p;
            this.title.set_text(p.title);
            this.author.set_text(p.author);
        }
    }
}
