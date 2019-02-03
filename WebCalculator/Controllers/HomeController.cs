using System.Web.Mvc;
using WebCalculator.Data;

namespace WebCalculator.Controllers
{
    public class HomeController : Controller
    {
        public ActionResult Index() => View();

        public ActionResult History() =>
            PartialView(
                "History",
                new DBContext().GetExpressions(Request.UserHostAddress)
                );

        [HttpPost]
        public void Add(string expression) =>
            new DBContext().AddExpression(Request.UserHostAddress, expression);
    }
}