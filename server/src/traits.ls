/**
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	path
	\./v : {revision}
	\./config : {config}
}

traits = {
	is-debug: config.DEBUG
	revision
	static-file: (file)->
		while (file.char-at 0) is '/'
			file = file.slice 1
		"#{path.join \/static, file}?v=#{revision}"
	static-dir: (dir)->
		dir = '' unless dir?
		while (dir.char-at 0) is '/'
			dir = dir.slice 1
		"#{path.join \/static, dir}"
}

export get = -> {} <<< traits
