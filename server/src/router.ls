/**
 * router module
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	\./pages/main
}

const routes =
	do
		url: /^\/$/
		handler: main.handler
		methods: <[get]>
	...


export init = (app)!->
	
	(route) <-! routes.for-each
	(method) <-! route.methods.for-each
	
	app[method] route.url, route.handler
