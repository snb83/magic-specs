using System;
using System.Linq.Expressions;
using Magic.Specs.Extensions;

namespace Magic.Specs
{
    /// <summary>
    /// Specification abstraction for type <typeparamref name="T"/>.
    /// </summary>
    /// <typeparam name="T">Type the specification is bound to.</typeparam>
    public class Spec<T>
        where T : class
    {
        /// <summary>
        /// Creates a new specification from predicate expression.
        /// </summary>
        /// <param name="expression"></param>
        public Spec(Expression<Func<T, bool>> expression)
        {
            Expression = expression;
        }

        /// <summary>
        /// Predicate expression that reflects the specification rule.
        /// </summary>
        public Expression<Func<T, bool>> Expression { get; }

        /// <summary>
        /// Implicit cast operator Spec{T} -> Expression{Func{T,bool}}.
        /// </summary>
        /// <param name="spec">Specification to cast from.</param>
        public static implicit operator Expression<Func<T, bool>>(Spec<T> spec)
            => spec.Expression;

        /// <summary>
        /// Implicit cast operator Spec{T} -> Func{T,bool}.
        /// </summary>
        /// <param name="spec">Specification to cast from.</param>
        public static implicit operator Func<T, bool>(Spec<T> spec)
            => spec.IsSatisfiedBy;

        public static bool operator false(Spec<T> spec) => false;

        public static bool operator true(Spec<T> spec) => true;

        /// <summary>
        /// Logical 'and' operator override.
        /// </summary>
        /// <param name="left">Left-hand specification.</param>
        /// <param name="right">Right-hand specification.</param>
        /// <returns>The combined specification.</returns>
        public static Spec<T> operator &(Spec<T> left, Spec<T> right)
            => new Spec<T>(left.Expression.And(right.Expression));

        /// <summary>
        /// Logical 'or' operator override.
        /// </summary>
        /// <param name="left">Left-hand specification.</param>
        /// <param name="right">Right-hand specification.</param>
        /// <returns>The combined specification.</returns>
        public static Spec<T> operator |(Spec<T> left, Spec<T> right)
            => new Spec<T>(left.Expression.Or(right.Expression));

        /// <summary>
        /// Logical 'not' operator override.
        /// </summary>
        /// <param name="spec">Specification to invert.</param>
        /// <returns>The inverted specification.</returns>
        public static Spec<T> operator !(Spec<T> spec)
            => new Spec<T>(spec.Expression.Not());

        /// <summary>
        /// Checks whether the specification is satisfied by the instance of entity/model.
        /// </summary>
        /// <param name="entity">Entity/model to check the specification agains.</param>
        /// <returns>True if specification is satisfied; false - otherwise.</returns>
        public bool IsSatisfiedBy(T entity)
        {
            var predicate = Expression.Compile();

            return predicate(entity);
        }
    }
}
