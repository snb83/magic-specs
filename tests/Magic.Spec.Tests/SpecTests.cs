using FluentAssertions;
using Magic.Specs;
using Xunit;

namespace Magic.Spec.Tests
{
    public class SpecTests
    {
        [Fact]
        public void SpecSimpleTest()
        {
            var notNullSpec = new Spec<object>(x => x != null);

            notNullSpec.IsSatisfiedBy(new object()).Should().BeTrue();
            notNullSpec.IsSatisfiedBy(null).Should().BeFalse();
        }
    }
}
