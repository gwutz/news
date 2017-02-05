/*
 * company.vala
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

namespace Lumber {

    public class Company : Object {
        static Company? _instance;
        private ThreadPool<void *> thread_pool = null;
        private AsyncQueue<Worker> queue = new AsyncQueue<Worker>();

        Company () {
            try {
                thread_pool = new ThreadPool<void *>.with_owned_data(
                    on_work_ready, 2, false
                );
            } catch (ThreadError e) {
                error(e.message);
            }
        }
        
        public static Company get_instance () {
            if (_instance == null)
                _instance = new Company ();
            return _instance;
        }

        private void on_work_ready (void *ignored) {
            var job = queue.pop ();
            job.execute ();
        }

        public void enqueue (Worker job) {
            queue.push(job);
            try {
                thread_pool.add(job);
            } catch (ThreadError e) {
                error(e.message);
            }
        }
        
    }

}
