using System;
using System.Linq;
using System.Collections.Generic;
using System.Text.RegularExpressions;
using WebCalculator.Data;

namespace WebCalculator.Models
{
    public class CalculatorModel
    {
        Dictionary<string, Func<double, double, double>> operations;
        DBContext db;
        string expression;
        CalculatorModel(string expression)
        {
            this.expression = expression;
            db = new DBContext();

            operations = new Dictionary<string, Func<double, double, double>>
            {
                { "+", (x, y) => x + y },
                { "-", (x, y) => x - y },
                { "*", (x, y) => x * y },
                { "/", (x, y) => x / y },
                { "mod", (x, y) => x % y},
                { "pow", (x, y) => Math.Pow(x, y)},
                { "sqrt", (x, y) => y !=0 ? Math.Pow(x, 1/y): 1/y}
            };


            db.AddExpression("127.0.0.1", expression);
        }
        public double Parse()
        {
            if (new Regex(@"^__________$").IsMatch(expression))
            {
                var fuck = from strings in _expression.Split('(')
                           from substrings in strings.Split(operations.Keys.ToArray(), StringSplitOptions.RemoveEmptyEntries)
                           from numbers in substrings
                            .Trim(new char[] { ' ', ')' })
                            .Cast<double>()
                           select new {op = operations.Keys, numbers };

                /*var numbers = _expression.Split(_operations.Keys.ToArray(), StringSplitOptions.RemoveEmptyEntries)
                    .Cast<double>()
                    .ToArray();
                string op = _operations.Keys.First(_expression.Contains);
                var result = _operations[op](numbers[0], numbers[1]);*/
            }
            throw new NotImplementedException();
        }
        double Eval(double r)
        {
            throw new NotImplementedException();
        }
        public void DefineOperation(string op, Func<double, double, double> funcs)
        {
            if (!operations.ContainsKey(op))
                throw new ArgumentException($"оператор {op} уже присутствует");
            operations.Add(op, funcs);
        }
        public double PerformOperation(string op, double x, double y)
        {
            if (!operations.ContainsKey(op))
                throw new ArgumentException($"Опреатор {op} не поддерживается");
            return _operations[op](x, y);
        }
    }
}