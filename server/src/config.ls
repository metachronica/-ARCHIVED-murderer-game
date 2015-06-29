/**
 * config module
 *
 * @author Viacheslav Lotsmanov <lotsmanov89@gmail.com>
 * @license GNU/AGPLv3
 * @see {@link https://www.gnu.org/licenses/agpl-3.0.txt|License}
 */

require! {
	path
	\js-yaml : yaml
	fs: {read-file-sync}
}

const config-file = path.resolve process.cwd!, \config.yaml

export config = yaml.safe-load read-file-sync config-file, \utf8
