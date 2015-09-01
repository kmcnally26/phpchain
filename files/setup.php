<?php
/**
 * Database setup script.
 * 
 * This file is part of phpChain.
 *
 * phpChain is free software; you can redistribute it and/or modify
 * it under the terms of the GNU General Public License as published by
 * the Free Software Foundation; either version 2 of the License, or
 * (at your option) any later version.
 * 
 * phpChain is distributed in the hope that it will be useful,
 * but WITHOUT ANY WARRANTY; without even the implied warranty of
 * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 * GNU General Public License for more details.
 * 
 * You should have received a copy of the GNU General Public License
 * along with phpChain; if not, write to the Free Software
 * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
 *
 * @package   phpChain
 * @version   $Id: setup.php,v 1.12 2006/01/10 00:52:44 gogogadgetscott Exp $
 * @link      http://phpchain.sourceforge.net/
 * @author    Scott Greenberg <me@gogogadgetscott.com>
 * @copyright Copyright (c) 2005-2006. SEG Technology. All rights reserved.
 */
define('PCH_FS_HOME'     , '.' . DIRECTORY_SEPARATOR);
if (is_file(PCH_FS_HOME . 'define.php')) {
    include PCH_FS_HOME   . 'define.php';
} else {
    die("Cannot find define.php file.\n");
}
$drop_table = false;
/*
 * Log user out when loading setup page.
 */
$pch->deleteCookie();
switch ($action) {
case 'reset':
    $dbusername = $pch->reqData('dbusername', VR_POST, VR_MIXED);
    $dbpassword = $pch->reqData('dbpassword', VR_POST, VR_PASSWORD);
    $pch->dbUsername($dbusername);
    $pch->dbPassword($dbpassword);
    $drop_table = true;
case 'setup':
    /*
     * Check if database exists. Create database if required.
     */
    if (!$pch->existsDatabase()) {
        $pch->createDatabase();
        $msgs[] = 'Created database.';
    }
    if (!$drop_table && $pch->statusTable(PCH_TABLE_USERS)) {
        $errors[] = 'Tables are already setup.';
        $action = 'preexist';
    } else {
        $msgs[] = 'Created database tables.';
        $action = 'complete';
        if (!$pch->createTables($db_tables, $drop_table)) {
            $errors[] = 'Unable to setup database.  You may preform this step manually.';
        }
    }

    break;
case 'delete':
    if (unlink(PCH_FS_HOME . 'setup.php')
        && unlink(PCH_FS_TEMPLATES . 'setup.tpl')) {
        $pch->redirect();
    }
    break;
default:
    /*
     * Check that PHP is of a sufficient version.
     */
    if (!$pch->checkVersion(PCH_VERSION_REQ)) {
        $version = phpversion();
        $errors[] = 'Sorry, PHP ' . PCH_VERSION_REQ 
            . ' or later is required (currently using version '
            . $version . ').';
    }
    break;
}
/*
 * Parse Smarty Header template.
 */
$pch->display('setup', 'Setup');

?>
