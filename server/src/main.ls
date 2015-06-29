/**
 * main module
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	path
	\colors/safe : c
	express
	\./config : {config}
	jade
	\./router
}

const static-path = path.resolve process.cwd!, \static
const tpl-path    = path.resolve process.cwd!, \front-end-src, \templates

app = express!

app
	.engine \jade, jade.__express
	.set \views, tpl-path
	.set 'view engine', \jade
	.use /^\/static/, express.static static-path

router.init app

{PORT, HOST} = config.SERVER

app.listen PORT, HOST, !->
	console.log "Listening on #{c.blue HOST}:#{c.blue PORT}"
