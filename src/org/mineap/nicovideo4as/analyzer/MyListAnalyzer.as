package org.mineap.nicovideo4as.analyzer
{
	import org.mineap.nicovideo4as.model.MyListItem;

	public class MyListAnalyzer
	{
		public function MyListAnalyzer()
		{
		}
		
		/**
		 * 
		 * @param xml
		 * 
		 */
		public function analyzer(xml:XML):Vector.<MyListItem>
		{
			
			var vector:Vector.<MyListItem> = new Vector.<MyListItem>();
			
			if (xml == null)
			{
				return vector;
			}
			
			if (xml.channel == null)
			{
				return vector;
			}
			
			var items:XMLList = (xml.channel as XMLList).children();
			
			for each(var xml:XML in items)
			{
				var myListItem:MyListItem = new MyListItem();
				
				myListItem.title = xml.title;
				myListItem.link = xml.link;
				myListItem.guid = xml.guid;
				if(xml.guid.@isPermaLink == "true"){
					myListItem.isPermaLink = true;
				}
				myListItem.pubDate = new Date(xml.pubDate);
				myListItem.description = xml.description;
				
				vector.push(myListItem);
			}
			
			return vector;
		}
		
	}
}