/*
 * controller.vala
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

using Tracker;
namespace News {
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
            StringBuilder builder = new StringBuilder ("
                SELECT 
                    nie:title(?msg) AS title
                    nmo:htmlMessageContent(?msg) AS content
                    nie:url(?msg) AS url
                    nco:fullname(?creator) AS fullname
                    nmo:isRead(?msg) AS is_read
                    ?msg BOUND(?tag) as is_starred
                    nie:contentCreated(?msg) AS date
                WHERE
                {
                    ?msg a mfo:FeedMessage");
                    
            if (unread) {
                builder.append ("; nmo:isRead false");
            }
            
            builder.append (". OPTIONAL {
                        ?msg nco:creator ?creator .
                        ?msg nao:hasTag ?tag .
                        FILTER(?tag = nao:predefined-tag-favorite)
                    }
                }
                ORDER BY DESC (nie:contentCreated(?msg))");
                    
            var result = sparql.query (builder.str);

            var posts = new List<Post>();
            while (result.next ()) {
                posts.append(new Post(parse_cursor(result)));
            }
            
            return posts;
        }
        
        public List<Post> post_sorted_by_channel (string url) {
            string query = """
                SELECT
                  nie:title(?msg) AS title
                  nmo:htmlMessageContent(?msg) AS content
                  nie:url(?msg) AS url
                  nco:fullname(?creator) AS fullname
                  nmo:isRead(?msg) AS is_read
                  ?msg BOUND(?tag) as is_starred
                  nie:url(?website) AS author_homepage
                  nco:emailAddress(?email) AS author_email
                  nie:contentCreated(?msg) AS date
                  { ?msg a mfo:FeedMessage;
                         nmo:communicationChannel ?chan .
                    ?chan nie:url "%s" .
                    OPTIONAL { ?msg nco:creator ?creator .
                               ?msg nao:hasTag ?tag .
                               FILTER(?tag = nao:predefined-tag-favorite) .
                               OPTIONAL { ?creator nco:hasEmailAddress ?email } .
                               OPTIONAL { ?creator nco:websiteUrl ?website }}
                  }
                ORDER BY DESC (nie:contentCreated(?msg))
            """.printf (url);
            
            var result = sparql.query (query);
            
            var posts = new List<Post>();
            while (result.next ()) {
                posts.append(new Post(parse_cursor(result)));
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
            try {
                sparql.update (query);
            } catch (DBusError derror) {
                error ("There was an error to communicate with the dbus interface %s", derror.message);
            } catch (IOError ioerror) {
                error ("There was an error to communicate with the io interface %s", ioerror.message);
            } catch (Error err) {
                error ("A general error occurred %s", err.message);
            }
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
        
        public void mark_post_as_starred (Post post, bool starred) {
            string query;
            if (starred) {
                query = """
                    INSERT
                      { ?msg nao:hasTag nao:predefined-tag-favorite }
                    WHERE
                      { ?msg nie:url "%s" }
                    """.printf (post.url);
            } else {
                query = """
                    DELETE
                      { ?msg nao:hasTag nao:predefined-tag-favorite }
                    WHERE
                      { ?msg nie:url "%s";
                             nao:hasTag nao:predefined-tag-favorite }
                    """.printf (post.url);
            }
            sparql.update (query);
        }
        
        public List<Feed> get_feed_list () {
            string query = """
                SELECT
                  nie:url(?chan) AS url
                  nie:title(?chan) AS title
                  { 
                    ?chan a mfo:FeedChannel
                  }
                ORDER BY nie:title(?chan)
                """;
            var result = sparql.query (query);
            var feeds = new List<Feed> ();
            while (result.next ()) {
                feeds.append (new Feed (result));
            }
            return feeds;
        }
        
        public void remove_channel (string url) {
            string query = """
                DELETE
                    { ?chan a rdfs:Resource }
                WHERE
                    { ?chan nie:url "%s" }
            """.printf (url);
            sparql.update (query);
        }
        
        private HashTable<string, Value?> parse_cursor (Sparql.Cursor cursor) {
            HashTable<string, Value?> parsed_data = new HashTable<string, Value?> (str_hash, str_equal);
            var n_columns = cursor.n_columns;
            
            for (int i = 0; i < n_columns; i++) {
                var vtype = cursor.get_value_type (i);

                switch (vtype) {
                    case Sparql.ValueType.STRING:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i)); break;
                    case Sparql.ValueType.BOOLEAN:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_boolean (i)); break;
                    case Sparql.ValueType.URI:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i)); break;
                    case Sparql.ValueType.INTEGER:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_integer (i)); break;
                    case Sparql.ValueType.DOUBLE:
                        parsed_data.insert (cursor.get_variable_name(i), cursor.get_double (i)); break;
                    default:
                        try {
                            parsed_data.insert (cursor.get_variable_name(i), cursor.get_string (i)); break;
                        } catch (Error e) {
                            error ("This shouldn't ever happen: %s", e.message);
                        }
                }
            }
            
            return parsed_data;
        }

    }
}
