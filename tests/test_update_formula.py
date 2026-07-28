from __future__ import annotations

import unittest

from scripts.update_formula import parse_checksums, parse_release, render_formula


class UpdateFormulaTest(unittest.TestCase):
    def setUp(self) -> None:
        self.version = "1.2.3"
        names = [
            f"ops-agent_{self.version}_{target}.tar.gz"
            for target in ("darwin-arm64", "darwin-amd64", "linux-amd64")
        ]
        self.release = parse_release(
            {
                "tag_name": f"v{self.version}",
                "assets": [
                    {
                        "name": name,
                        "browser_download_url": (
                            "https://github.com/Chengyunlai/ops-agent/"
                            f"releases/download/v{self.version}/{name}"
                        ),
                    }
                    for name in [*names, "SHA256SUMS"]
                ],
            }
        )
        self.checksums = {
            name: str(index) * 64 for index, name in enumerate(names, start=1)
        }

    def test_render_formula_contains_all_platforms_and_installation(self) -> None:
        formula = render_formula(self.release, self.checksums)

        self.assertIn('version "1.2.3"', formula)
        self.assertIn('license "Apache-2.0"', formula)
        self.assertIn("on_macos do", formula)
        self.assertIn("on_linux do", formula)
        self.assertIn("depends_on arch: :x86_64", formula)
        self.assertEqual(formula.count("releases/download/v1.2.3"), 3)
        self.assertIn('bin.install "ops-agent", "ops_agent"', formula)
        self.assertIn('pkgshare.install "config.example.toml"', formula)

    def test_missing_archive_is_rejected(self) -> None:
        self.checksums.pop("ops-agent_1.2.3_linux-amd64.tar.gz")

        with self.assertRaisesRegex(
            ValueError,
            "release is missing ops-agent_1.2.3_linux-amd64.tar.gz",
        ):
            render_formula(self.release, self.checksums)

    def test_checksum_file_must_be_well_formed(self) -> None:
        with self.assertRaisesRegex(ValueError, "invalid SHA256SUMS line"):
            parse_checksums("not-a-checksum archive.tar.gz\n")


if __name__ == "__main__":
    unittest.main()
