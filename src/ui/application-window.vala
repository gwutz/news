/*
 * application-window.vala
 * This file is part of news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace News.UI {

    [GtkTemplate (ui = "/org/gnome/News/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow {
        
        private bool is_flow = true;

        [GtkChild (name = "Stack")]
        private Gtk.Stack stack;

        [GtkChild (name = "ViewMode")]
        private Gtk.Button view_mode;
        
        [GtkChild (name = "BackButton")]
        private Gtk.Button back_btn;
        
        [GtkChild (name = "StarButton")]
        private Gtk.Button star_btn;
        
        [GtkChild (name = "SearchButton")]
        private Gtk.ToggleButton search_btn;
        
        [GtkChild (name = "AddFeed")]
        private Gtk.MenuButton add_feed_btn;
        
        [GtkChild (name = "StackSwitcher")]
        private Gtk.StackSwitcher switcher;
        
        [GtkChild (name = "NewUrl")]
        private Gtk.Entry new_url;
        
        [GtkChild (name = "NewUrlButton")]
        private Gtk.Button new_url_btn;
        
        [GtkChild (name = "SearchBar")]
        private Gtk.SearchBar search_bar;
        
        [GtkChild (name = "SearchEntry")]
        private Gtk.SearchEntry search_entry;
        
        private Gtk.Widget previous_view = null;

        public Window (Application app) {
            Object (application: app);

            view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
            
            this.back_btn.clicked.connect (return_article);
            
            var new_view = new News.UI.NewView ();
            stack.add_titled (new_view, new_view.name, new_view.name);
            
            var feed_view = new News.UI.FeedView ();
            stack.add_titled (feed_view, feed_view.name, feed_view.name);
            
            var star_view = new News.UI.StarView ();
            stack.add_titled (star_view, star_view.name, star_view.name);
            
            var search_view = new News.UI.SearchView ();
            search_entry.bind_property ("text", search_view, "search_query");
            stack.add_named (search_view, search_view.name);
            
            var article_view = new News.UI.ArticleView ();
            stack.add_named (article_view, article_view.name);
            
            stack.notify["visible-child"].connect (view_changed);
            view_changed ();
        }
        
        private void view_changed () {
            var to_view = stack.get_visible_child ();
            if (to_view is News.UI.Updateable) {
                var updateable = to_view as News.UI.Updateable;
                updateable.update ();
            }
        }
        
        internal void show_article (News.Post post) {
            //article = new ArticleView ();
            search_bar.set_search_mode (false);
            var article = stack.get_child_by_name ("Article") as ArticleView;
            article.post =  post;
            article.show_all ();
            this.previous_view = this.stack.get_visible_child ();
            //this.stack.add_named (article, "feedview");
            this.stack.set_visible_child (article);
            this.stack.show_all ();
            set_headerbar_article (post);
            var app = get_application () as Application;
            app.controller.mark_post_as_read (post);
        }
        
        private void return_article (Gtk.Button btn) {
            this.search_entry.text = "";
            this.stack.set_visible_child (this.previous_view);
            this.previous_view = null;
            set_headerbar_main ();
        }
        
        private void set_headerbar_article (Post post) {
            this.add_feed_btn.hide ();
            this.switcher.hide ();
            this.search_btn.hide ();
            this.view_mode.hide ();
            this.star_btn.show ();
            this.back_btn.show ();
            
            if (post.starred) {
                this.star_btn.set_image (new Gtk.Image.from_icon_name ("starred-symbolic", Gtk.IconSize.MENU));
            } else {
                this.star_btn.set_image (new Gtk.Image.from_icon_name ("non-starred-symbolic", Gtk.IconSize.MENU));
            }
        }
        
        private void set_headerbar_search () {
            this.add_feed_btn.hide ();
            this.switcher.hide ();
            this.view_mode.hide ();
            this.back_btn.show ();
        }
        
        private void set_headerbar_main () {
            this.add_feed_btn.show ();
            this.switcher.show ();
            this.search_btn.show ();
            this.view_mode.show ();
            this.back_btn.hide ();
            this.star_btn.hide ();
        }

        
        [GtkCallback]
        private void star_article (Gtk.Button btn) {
            var app = get_application () as Application;
            var article = stack.get_child_by_name ("Article") as ArticleView;
            if (article.post.starred) {
                this.star_btn.set_image (new Gtk.Image.from_icon_name ("non-starred-symbolic", Gtk.IconSize.MENU));
            } else {
                this.star_btn.set_image (new Gtk.Image.from_icon_name ("starred-symbolic", Gtk.IconSize.MENU));
            }
            app.controller.mark_post_as_starred (article.post, !article.post.starred);
            article.post.starred = !article.post.starred;
        }
        
        [GtkCallback]
        private void mode_switched () {
        
            var active_view = stack.get_visible_child ();
            if (active_view is Switchable) {
                (active_view as Switchable).switch_mode ();
            }
            if (is_flow) {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-grid-symbolic", Gtk.IconSize.MENU));
            } else {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
            }
            is_flow = !is_flow;
        }
        
        [GtkCallback]
        private void add_new_url (Gtk.Button button) {
                var app = get_application () as Application;
                app.controller.add_channel (new_url.get_text ());
        }
        
        [GtkCallback]
        private void search_btn_toggled () {
            if (search_bar.search_mode_enabled) {
                search_bar.set_search_mode (false);
            } else {
                search_bar.set_search_mode (true);
            }
        }

        [GtkCallback]
        private void on_url_changed (Gtk.Editable entry) {
            var url = new_url.get_text ();
            if (url.length == 0) {
                new_url_btn.set_sensitive (false);
            } else {
                new_url_btn.set_sensitive (true);
            }
        }
        
        [GtkCallback]
        private void on_search_changed () {
            if (search_entry.text_length > 0) {
                if (stack.get_visible_child_name () != "Search") {
                    previous_view = stack.get_visible_child ();
                    set_headerbar_search ();
                    stack.set_visible_child_name ("Search");
                }
            }
        }
    }
}
