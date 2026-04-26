package pitstop;

class SongList
{

    public static var SONGLIST:Array<Array<Dynamic>> = [
		#if debug
        ['Test', 0, 'bf'],
        #end
        ['Tutorial', 0, 'gf'],
        #if INCLUDE_WEEK1
        ['Bopeebo', 1, 'dad'],
        ['Fresh', 1, 'dad'],
        ['Dadbattle', 1, 'dad'],
        #end
        ['Argue Park', 1, 'dad'],
    ];
    
}