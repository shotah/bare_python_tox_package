"""Install deps first: pip install -r requirements.txt, then: python demo.py."""

from hello_world import __version__, greet, hello_world


def main() -> None:
    print(hello_world())
    print(greet("reader"))
    print(f"(hello-world-package {__version__})")


if __name__ == "__main__":
    main()
