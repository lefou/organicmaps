#include "testing/testing.hpp"

#include "geometry/point2d.hpp"
#include "geometry/polyline2d.hpp"
#include "geometry/rect2d.hpp"

#include "base/math.hpp"

namespace
{
double constexpr kEps = 1e-5;

void TestClosest(m2::PolylineD const & poly, m2::PointD const & point, double expectedSquaredDist,
                 uint32_t expectedIndex)
{
  auto const closest = poly.CalcMinSquaredDistance(m2::PointD(point));
  TEST(base::AlmostEqualAbs(closest.first, expectedSquaredDist, kEps),
       (closest.first, expectedSquaredDist));
  TEST_EQUAL(closest.second, expectedIndex, (closest.second, expectedIndex));
}

UNIT_TEST(Rect_PolylineSmokeTest)
{
  m2::PolylineD poly = {{0.0, 0.0}, {1.0, 0.0}, {1.0, 1.0}};
  TEST_EQUAL(poly.GetSize(), 3, ());
  TEST(base::AlmostEqualAbs(poly.GetLength(), 2.0, kEps), ());

  auto const limitRect = poly.GetLimitRect();
  TEST(base::AlmostEqualAbs(limitRect.LeftBottom(), m2::PointD(0.0, 0.0), kEps), ());
  TEST(base::AlmostEqualAbs(limitRect.RightTop(), m2::PointD(1.0, 1.0), kEps), ());

  poly.PopBack();
  TEST_EQUAL(poly.GetSize(), 2, ());
}

UNIT_TEST(Rect_PolylineMinDistanceTest)
{
  // 1 |              |
  //   |              |
  //   0----1----2----3
  m2::PolylineD const poly = {{0.0, 1.0}, {0.0, 0.0}, {1.0, 0.0},
                              {2.0, 0.0}, {3.0, 0.0}, {3.0, 1.0}};

  TestClosest(poly, m2::PointD(0.0, 1.0), 0.0 /* expectedSquaredDist */, 0 /* expectedIndex */);
  TestClosest(poly, m2::PointD(0.0, 0.0), 0.0 /* expectedSquaredDist */, 0 /* expectedIndex */);
  TestClosest(poly, m2::PointD(0.1, 0.0), 0.0 /* expectedSquaredDist */, 1 /* expectedIndex */);
  TestClosest(poly, m2::PointD(0.5, 0.2), 0.2 * 0.2 /* expectedSquaredDist */, 1 /* expectedIndex */);
  TestClosest(poly, m2::PointD(1.5, 1.0), 1.0 /* expectedSquaredDist */, 2 /* expectedIndex */);
  TestClosest(poly, m2::PointD(1.5, -5.0), 5.0 * 5.0 /* expectedSquaredDist */, 2 /* expectedIndex */);
  TestClosest(poly, m2::PointD(1.5, 5.0), 4.0 * 4.0 + 1.5 * 1.5 /* expectedSquaredDist */, 0 /* expectedIndex */);
  TestClosest(poly, m2::PointD(3.0, 1.0), 0.0 /* expectedSquaredDist */, 4 /* expectedIndex */);
}
}  // namespace

