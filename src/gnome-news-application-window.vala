/*
 * gnome-news-application-window.vala
 * This file is part of gnome news
 *
 * Copyright (C) 2017 - Günther Wutz
 *
 * gnome news is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 *
 * gnome news is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 *
 * You should have received a copy of the GNU General Public License
 * along with gnome news. If not, see <http://www.gnu.org/licenses/>.
 */

namespace GnomeNews {

    [GtkTemplate (ui = "/org/gnome/News/ui/window.ui")]
    public class Window : Gtk.ApplicationWindow {
    
        public Gtk.FlowBox new_article_flow;
        public Gtk.ListBox new_article_list;
        private ArticleView article;
    
        [GtkChild (name = "ArticleView")]
        public Gtk.Viewport article_view;
        
        private bool is_flow = true;

        [GtkChild (name = "Stack")]
        private Gtk.Stack stack;

        [GtkChild (name = "ViewMode")]
        private Gtk.Button view_mode;
        
        [GtkChild (name = "BackButton")]
        private Gtk.Button back_btn;
        
        [GtkChild (name = "AddFeed")]
        private Gtk.MenuButton add_feed_btn;
        
        [GtkChild (name = "StackSwitcher")]
        private Gtk.StackSwitcher switcher;
        
        [GtkChild (name = "NewUrl")]
        private Gtk.Entry new_url;
        
        [GtkChild (name = "NewUrlButton")]
        private Gtk.Button new_url_btn;
        
        
        private Gtk.Widget previous_view = null;

        public Window (Application app) {
            Object (application: app);
            //stack.notify["visible-child"].connect (view_changed);
            var builder = new Gtk.Builder.from_resource ("/org/gnome/News/ui/article.ui");
            this.new_article_flow = builder.get_object("NewArticleFlow") as Gtk.FlowBox;
            article_view.add (new_article_flow);
            this.new_article_list = builder.get_object("NewArticleList") as Gtk.ListBox;
            view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
            
            this.new_article_flow.child_activated.connect (show_article_flow);
            this.new_article_list.row_activated.connect (show_article_list);
            
            this.back_btn.clicked.connect (return_article);
            
            //app.controller.items_updated.connect (items_updated);
            app.controller.feeds_updated.connect (feeds_updated);
            
            app.controller.item_updated.connect (item_updated);
        }

        /*private void view_changed() {

        }*/
        
        private void show_article_flow (Gtk.FlowBoxChild child) {
            Post post = ((PostImage)child.get_child()).post;
            show_article (post);
        }
        
        private void show_article_list (Gtk.ListBoxRow row) {
            Post post = ((ArticleList)row.get_child()).post;
            show_article (post);
        }
        
        private void show_article (Post post) {
            
            article = new ArticleView ();
            article.set_post (post);
            article.show ();
            this.previous_view = this.stack.get_visible_child ();
            this.stack.add_named (article, "feedview");
            this.stack.set_visible_child (article);
            set_headerbar_article ();
            var app = get_application () as GnomeNews.Application;
            app.controller.mark_post_as_read (post);
        }
        
        private void return_article (Gtk.Button btn) {
            
            this.stack.set_visible_child (this.previous_view);
            this.previous_view = null;
            this.stack.remove (this.article);
            this.article = null;
            set_headerbar_main ();
        }
        
        private void set_headerbar_article () {
            this.add_feed_btn.hide ();
            this.switcher.hide ();
            this.back_btn.show ();
        }
        
        private void set_headerbar_main () {
            this.add_feed_btn.show ();
            this.switcher.show ();
            this.back_btn.hide ();
        }
        
        private void item_updated (Post post, Controller.Updated updated) {
            if (updated == Controller.Updated.MARK_AS_READ) {
                var children = this.new_article_flow.get_children ();
                foreach (Gtk.Widget w in children) {
                    var flowboxchild = w as Gtk.FlowBoxChild;
                    var item = flowboxchild.get_child () as PostImage;
                    if (item != null && item.post == post) {
                        debug ("Found Post - destroy it: %s", post.url);
                        flowboxchild.destroy ();
                        break;
                    }
                }
            }
            
        }
        
        private void feeds_updated () {
        
        }
        
        [GtkCallback]
        private void mode_switched () {
            var app = get_application () as GnomeNews.Application;
            
            // remove widgets from current view
            List<weak Gtk.Widget> children = null;
            if (is_flow) {
                children = new_article_flow.get_children ();
            } else {
                children = new_article_list.get_children ();
            }
            foreach (Gtk.Widget w in children)
                w.destroy ();
            
            // populate with new widgets
            var posts = app.controller.post_sorted_by_date(true);
            if (is_flow) {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-grid-symbolic", Gtk.IconSize.MENU));
                this.article_view.remove (new_article_flow);
                this.article_view.add (new_article_list);

                foreach (Post p in posts)
                    new_article_list.add (new ArticleList (p));
            } else {
                view_mode.set_image (new Gtk.Image.from_icon_name ("view-list-symbolic", Gtk.IconSize.MENU));
                this.article_view.remove (new_article_list);
                this.article_view.add (new_article_flow);
                
                foreach (Post p in posts)
                    new_article_flow.add (new PostImage (p));
            }

            is_flow = !is_flow;
        }
        
        [GtkCallback]
        private void add_new_url (Gtk.Button button) {
                var app = get_application () as GnomeNews.Application;
                app.controller.add_channel (new_url.get_text ());
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
    }
}
