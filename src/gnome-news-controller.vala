/*
 * gnome-news-controller.vala
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

using Tracker;
namespace GnomeNews {
    public class Controller : Object {
    
        public enum Updated {
            MARK_AS_READ
        }
    
        public signal void items_updated ();
        public signal void feeds_updated ();
        
        public signal void item_updated (Post post, Updated updated);
    
        private Sparql.Connection sparql;

        public Controller () {
            try {
                sparql = Sparql.Connection.get ();
            } catch ( Error e ){
                error (e.message);
            }
        }
        
        public List<Post> post_sorted_by_date (bool unread = false) {
            debug ("Start Querying DB");
            StringBuilder builder = new StringBuilder ("
                SELECT 
                    nie:title(?msg) AS title
                    nmo:htmlMessageContent(?msg) AS content
                    nie:url(?msg) AS url
                    nco:fullname(?creator) AS fullname
                WHERE
                {
                    ?msg a mfo:FeedMessage");
            /*string query = """
                SELECT 
                    nie:title(?msg) AS title
                    nmo:htmlMessageContent(?msg) AS content
                    nie:url(?msg) AS url
                    nco:fullname(?creator) AS fullname
                WHERE
                {
                    ?msg a mfo:FeedMessage""";*/
            
            if (unread) {
                builder.append ("; nmo:isRead false");
            }
            
            builder.append (". OPTIONAL {
                        ?msg nco:creator ?creator
                    }
                }
                ORDER BY DESC (nie:contentCreated(?msg))");
                    
            var result = sparql.query (builder.str);
            debug ("Querying Done");
            var posts = new List<Post>();
            while (result.next ()) {
                posts.append(new Post(result));
            }
            
            return posts;
        }
        
        public void add_channel (string url, int update_interval = 5) {
            string query = """
                INSERT {
                  _:FeedSettings a mfo:FeedSettings ;
                                   mfo:updateInterval %i .
                  _:Feed a nie:DataObject, mfo:FeedChannel ;
                           mfo:feedSettings _:FeedSettings ;
                           nie:url "%s" }
            """.printf (update_interval, url);
            sparql.update (query);
        }
        
        public void mark_post_as_read (Post post) {
            debug ("Url read: %s", post.url);
            string query = """
                DELETE
                  { ?msg nmo:isRead ?any }
                WHERE
                  { ?msg nie:url "%s";
                         nmo:isRead ?any }
                INSERT
                  { ?msg nmo:isRead true }
                WHERE
                  { ?msg nie:url "%s" }
            """.printf(post.url, post.url);
            sparql.update (query);
            item_updated (post, Updated.MARK_AS_READ);
        }

    }
}
