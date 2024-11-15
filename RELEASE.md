# Guide for publication

1. Create a branch with the name of the version `x.x.x`

2. Change the version in [version.rb](version.rb) file
    ```ruby
    $VERSION = 'x.x.x'
    ```

3. Run `pod update` to install the new version of this library
    ```shell
    pod update
    ```
4. If Reach5 has been upgraded to a new major version, update the version in [Package.swift](Package.swift) <br>
Update to latest package versions of dependencies for SPM in XCode or with this command
    ```shell
    swift package update
    ```

5. Update the [CHANGELOG.md](CHANGELOG.md) file

6. Test the modifications on the SPM project DemoSharedCredentials. SPM tends to be stricter than Cocoapods when validating dependencies and code visibility.

7. Submit and merge the pull request

8. Add git tag `x.x.x` to the merge commit
    ```sh
    git tag x.x.x
    ```

9. Push the tag
    ```sh
    git push origin x.x.x
    ```

10. The CI will automatically publish this new version

11. Finally, draft a new release in the [Github releases tab](https://github.com/ReachFive/reachfive-ios-google/releases) (copy & paste the changelog in the release's description).
