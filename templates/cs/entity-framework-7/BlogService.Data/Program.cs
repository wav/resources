using System;

namespace BlogService.Data 
{
	public class Program
	{
		public static void Main()
		{
			var context = new BloggingContext();
			var service = new BlogService(context);
			service.AddBlog ("hello", "http://example.com/hello");
			foreach(var blog in service.GetAllBlogs()) {
				Console.WriteLine (blog.ToString ());
			}
		}
	}	
}