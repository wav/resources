using System.Linq;
using System.Collections.Generic;
using Microsoft.Data.Entity;

namespace BlogService
{
	public class BloggingContext : DbContext 
	{ 
		public virtual DbSet<Blog> Blogs { get; set; } 
		public virtual DbSet<Post> Posts { get; set; } 

		protected override void OnConfiguring(DbContextOptionsBuilder options)
		{
			options.UseInMemoryStore (false);
		}
	} 

	public class Blog 
	{ 
		public int BlogId { get; set; } 
		public string Name { get; set; } 
		public string Url { get; set; } 

		public virtual List<Post> Posts { get; set; } 

		public override string ToString ()
		{
			return string.Format ("[Blog: BlogId={0}, Name={1}, Url={2}, Posts={3}]", BlogId, Name, Url, Posts);
		}
	} 

	public class Post 
	{ 
		public int PostId { get; set; } 
		public string Title { get; set; } 
		public string Content { get; set; } 

		public int BlogId { get; set; } 
		public virtual Blog Blog { get; set; } 

		public override string ToString ()
		{
			return string.Format ("[Post: PostId={0}, Title={1}, Content={2}, BlogId={3}, Blog={4}]", PostId, Title, Content, BlogId, Blog);
		}
	}

	public class BlogService
	{
		private BloggingContext _context; 

		public BlogService(BloggingContext context) 
		{ 
			_context = context; 
		}

		public Blog AddBlog(string name, string url) 
		{ 
			var blog = _context.Blogs.Add(new Blog { Name = name, Url = url }); 
			_context.SaveChanges(); 
			return blog.Entity;
		} 

		public List<Blog> GetAllBlogs() 
		{ 
			var query = from b in _context.Blogs 
				orderby b.Name 
				select b; 

			return query.ToList(); 
		} 
	}
}

